classdef serratedPointJump2 < matlab.mixin.SetGet

	% Change into a function that handles the new stepping from optimal params
	% Used to then create a plot of the objective function space

	properties
		crypt
		optimalPoint

		cryptName
		objectiveFunction
		healthyParams
		serratedParams

		logicalIndices

		points


		penaltyLine
		anoikisLine

		pValues

		imageLocation
		
		dataFilePenalty
		dataFileAnoikis
		imageFileCount
		imageFileTurnover
		imageFileCompartment




	end

	methods

		function obj = serratedPointJump2(crypt, optimalPoint, n, varargin)
			% Starting at an optimalPoint, we jump to the closest known serrated point
			% by jumping each parameter and combination of parameters from optimal to serrated values


			obj.crypt 				= crypt;
			obj.optimalPoint 		= optimalPoint;

			obj.cryptName 			= getCryptName(crypt);
			obj.objectiveFunction 	= str2func(obj.cryptName);

			obj.healthyParams 		= getOptimalParams(crypt, optimalPoint);
			obj.serratedParams 		= getSerratedParams2(crypt, optimalPoint, n);


			obj.imageLocation = sprintf('%s/Research/Crypt/Images/serratedPointJump2/%s/',getenv('HOME'), obj.cryptName);
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.dataFilePenalty			= sprintf('%sPoint%dPenalty.txt',obj.imageLocation,obj.optimalPoint);
			obj.dataFileAnoikis 		= sprintf('%sPoint%dAnoikis.txt',obj.imageLocation,obj.optimalPoint);
			obj.imageFileCount 			= sprintf('%sCellCount',obj.imageLocation);
			obj.imageFileTurnover 		= sprintf('%sCellTurnoverRate',obj.imageLocation);
			obj.imageFileCompartment 	= sprintf('%sCompartmentCount',obj.imageLocation);
			
			obj.makePointsToVisit();

		end

		function makePointsToVisit(obj)
			% Starting from the optimal point change the parameters to
			% the serrated value in every possible combination.
			% This means creating every possible subset from 1:7

			N = 7;

			% Make a cell array of all possible combinations

			obj.logicalIndices = double(dec2bin(0:2^N-1,N))==48;

			for i=1:length(obj.logicalIndices)
				points(i,:) = obj.healthyParams;
				points(i,obj.logicalIndices(i,:)) = obj.serratedParams(obj.logicalIndices(i,:));
			end

			obj.points = points;

		end


		function collateResults(obj, varargin)
			% Gets all the data for the short sweep

			penalty = nan(1,length(obj.points));
			anoikis = nan(1,length(obj.points));
			for i=1:length(obj.points)

				n = obj.points(i,1);
				np = obj.points(i,2);
				ees = obj.points(i,3);
				ms = obj.points(i,4);
				cct = obj.points(i,5);
				wt = obj.points(i,6);
				vf = obj.points(i,7);

				try
					b = setBehaviour(obj.objectiveFunction,n,np,ees,ms,cct,wt,vf,varargin);
					penalty(i) = b.b.getPenalty(varargin);
					anoikis(i) = b.b.simul.data.behaviour_data(1);
				end

			end

			obj.penaltyLine = penalty';
			obj.anoikisLine = anoikis';

		end

		function tTestResults(obj, varargin)
			% The points have every combination of parameter being from the healthy or serrated set
			% This test look at each variable in turn
			% The points are broken into two sets, one where the parameter is 'on' i.e. serrated
			% or 'off' i.e. healthy. Since every combination is found in points, we can pair parameter
			% sets in the on category, with the off category, where all other states are the same

			% We then take the mean value of the anoikis rate of the two categories, and perform a hypothesis
			% test to determine if the means are different between the two categories
			obj.collateResults(varargin);
			
			for i = 1:7
				on = obj.anoikisLine(obj.logicalIndices(:,i)==1);
				off = obj.anoikisLine(obj.logicalIndices(:,i)==0);
				
				meanOn(i) = nanmean(on);
				meanOff(i) = nanmean(off);
				stdevOn(i) = nanstd(on);
				stdevOff(i) = nanstd(off);
				nOn(i) = sum(~isnan(on));
				nOff(i) = sum(~isnan(off));
			   
			end

			bottom = sqrt( stdevOn.^2./nOn + stdevOff.^2./nOff );
			top = meanOn - meanOff;
				
			tvalue = top./bottom;

			obj.pValues = 1-tcdf(abs(tvalue),min(nOn-1, nOff-1))+tcdf(-abs(tvalue),min(nOn-1, nOff-1));


		end

		function saveResults(obj, varargin)
			% Put the results into a text file.
			% This is probably better done with a dataType object
			% But I have 20 minutes to pull it together

			obj.collateResults(varargin);

			output = [obj.logicalIndices,obj.penaltyLine];

			csvwrite(obj.dataFilePenalty, output);

			output = [obj.logicalIndices,obj.anoikisLine];

			csvwrite(obj.dataFileAnoikis, output);


		end

	end

end