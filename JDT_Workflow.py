# Author     : Jered Dominguez-Trujillo
# Date       : April 10, 2019
# Description: Generates Modified Stagen File from Original Stagen File

# Import Statements
import os
import argparse
import datetime
import time
import re
import shutil
import csv

# Global Variables and Paths
home_dir           = '/mnt/clifford/jereddt/Research/01_Workflow/'
dir_current        = home_dir + '02_Runs/Denis_Design/J_03-05-19/06_N100_R180/pb_142500'
stagen_original    = home_dir + 'stagen_original.dat'
geometry_original  = home_dir + 'Input.csv'
geometry_new       = 'Geo_Output.csv'
figures            = 'Figures'

# Executables
MEANGEN                = '01-jdt-meangen-17.4'
STAGEN                 = '02-jdt-stagen-17.4'
MULTALL                = '03-jdt-multall-18.5'
CONVERT_TO_MATLAB      = '04-jdt-convert-to-matlab'
CONVERT_TO_TECPLOT     = '05-jdt-convert-to-tecplot'

MEANGEN_EXE            = home_dir + MEANGEN
STAGEN_EXE             = home_dir + STAGEN
MULTALL_EXE            = home_dir + MULTALL
CONVERT_TO_MATLAB_EXE  = home_dir + CONVERT_TO_MATLAB
CONVERT_TO_TECPLOT_EXE = home_dir + CONVERT_TO_TECPLOT

# Subdirectories
MATLAB                 = home_dir + '01_MATLAB/'
RUNS                   = home_dir + '02_Runs/'
TECPLOT                = home_dir + '05_Tecplot/'

# Tecplot Macros
FLOW_FIELD             = TECPLOT + 'FLOW_FIELD.mcr'
MERIDIONAL             = TECPLOT + 'MERIDIONAL.mcr'
BLADES_3D              = TECPLOT + '3D-blades.mcr'

# MATLAB Input Files
BLADE                  = 'blade.dat'
GRID2D                 = 'grid2d.dat'
STAGE_NEW              = 'stage_new.dat'
INTYPE                 = 'intype'
MATLAB_FILE            = 'matlab.dat'
TECPLOT_FILE           = 'tecplot-input-2.dat'
MERIDIONAL_FILE        = 'PW_Meridional.dat'

# P&W Files
dppop                  = MATLAB + 'res/dppop.csv'
angles                 = MATLAB + 'res/PW_angles.csv'
dfactor                = MATLAB + 'res/dfactor.dat'
pwstag                 = MATLAB + 'res/PW_stagnation_conditions.csv'
pstagold               = MATLAB + 'res/PSTAG_IN_0826_7.dat'
tstagold               = MATLAB + 'res/TSTAG_IN_0826_7.dat'

xrotor                 = MATLAB + 'res/x_frac_rotor.csv'
xstator                = MATLAB + 'res/x_frac_stator.csv'
PW_Mach                = MATLAB + 'res/PW_Mach.csv'
Mach_PS                = 'MACH_PS.dat'
Mach_SS                = 'MACH_SS.dat'

# Run Variables
REYNOLDS               = 180000
TIN                    = home_dir + 'TIN.dat'
PIN                    = home_dir + 'PIN.dat'
PBACK                  = 142500

# Control Points Used to Define Blade
CONTROL_POINTS = 6

# Main Runner
def main():
	# Print Header
	header()

	# User Input
	dir_new, stagen_new, reynolds, pback = user_input()

	# Make New Directory and Copy Necessary Files
	commands = ['mkdir ' + dir_new                                                                 ,
                    'mkdir ' + dir_new                + '/' + figures                              ,
                    'cp '    + stagen_original        + ' ' + stagen_new                           ,
                    'cp '    + MEANGEN_EXE            + ' ' + dir_new    + '/' + MEANGEN           ,
		            'cp '    + STAGEN_EXE             + ' ' + dir_new    + '/' + STAGEN            ,
		            'cp '    + MULTALL_EXE            + ' ' + dir_new    + '/' + MULTALL           ,
                    'cp '    + CONVERT_TO_MATLAB_EXE  + ' ' + dir_new    + '/' + CONVERT_TO_MATLAB ,
                    'cp '    + CONVERT_TO_TECPLOT_EXE + ' ' + dir_new    + '/' + CONVERT_TO_TECPLOT,]

	# Execute Command List
	execute_commands(commands) 

	# Change Working Directory
	change_wd(dir_new)

	# Get Blade Geometry Information
	THICKNESS_ATTR, CAMBER_ATTR = geo(geometry_original)

	# User Geometry Changes
	THICKNESS_ATTR, CAMBER_ATTR = geo_input(THICKNESS_ATTR, CAMBER_ATTR)
	
	# Write New Geometry File
	geo_output(geometry_new, THICKNESS_ATTR, CAMBER_ATTR)

	# Generate New Stage File	
	new_stagen(stagen_new, THICKNESS_ATTR, CAMBER_ATTR)

	# Run Stagen Command
	run_stagen(stagen_new)

	# Generate Blade Profiles
	blade_profiles(dir_new)

	# Modify stage_new file
	modify_stage_new(STAGE_NEW, reynolds, TIN, PIN, pback)

	# Run Multall Command
	run_multall()

	# Generate MATLAB and TECPLOT Files
	generate_matlab()
	generate_tecplot()

	# Generate Figures
	results_matlab(dir_new, MATLAB_FILE)
<<<<<<< HEAD
	results_tecplot(dir_new, TECPLOT_FILE, MERIDIONAL_FILE)
=======
	# results_tecplot(dir_new, TECPLOT_FILE, MERIDIONAL_FILE)
>>>>>>> c22b3c18b1cc1774de9b37b973c5e7d0a24630da
	results_compare(dir_current, dir_new)

# Print Header
def header():
	# Header
	print('GENERATE STAGEN FILE SCRIPT\n')
	print('Author: Jered Dominguez-Trujillo\n')

	# Get Current Working Directory
	cwd = os.getcwd()
	print('CURRENT WORKING DIRECTORY: ' + cwd + '\n')

# User Input
def user_input():
	# User Input: New Working Directory Name
	dir_new = RUNS + raw_input('Enter New Directory Name:\n')	

	# User Input: New Stagen File Name
	stagen_new = dir_new + '/' + raw_input('Enter New Stagen File Name:\n')

	# User Input: Reynolds Number and Back Pressure
	R   = raw_input('\nEnter Reynolds Number (Default 180000):\n')
	PB = raw_input('Enter Back Pressure [Pa] (Default: 142.5 kPa):\n')

	if R != '':
		reynolds = int(R.strip())
	else:
		reynolds = REYNOLDS

	if PB != '':
		pback = int(PB.strip())
	else:
		pback = PBACK

	return dir_new, stagen_new, reynolds, pback

# Get Blade Geometry Information from File
def geo(geofile):
	# Open File for Reading
	with open(geofile, 'rb') as f:
		reader = csv.reader(f, delimiter = '\t')
		geo = list(reader)

	# Section Headers
	HEADER1 = ['ROW', 'SECTION', 'TKLE', 'TKTE' , 'TKMAX', 'XTMAX', 'XMODLE', 'XMODTE', 'TK_TYP']
	HEADER2 = ['ROW', 'SECTION', 'X'   , 'ANGLE']

	# Get List Index of Blank Line Separating Two Sections
	BLANK_IDX = [i for i in range(0, len(geo)) if geo[i] == []]
	
	# Checks: Only 1 Blank Line
	if len(BLANK_IDX) == 1:
		BLANK_IDX = BLANK_IDX[0]
		# Checks that Headers are Valid
		if HEADER1 != geo[0] or HEADER2 != geo[BLANK_IDX+1]:
			print('Error, bad input file')
			exit()
	else:
		print('Error, bad input file') 
		exit()

	# Split Geometry Information into Thickness and Camber Attributes
	THICKNESS_ATTR = geo[:BLANK_IDX]
	CAMBER_ATTR    = geo[BLANK_IDX+1:]

	return THICKNESS_ATTR, CAMBER_ATTR

def geo_input(thickness, camber):
	loop_thickness = True

	while loop_thickness:
		flag_thickness = raw_input('Are any changes in thickness properties desired?(y/n)')

		if flag_thickness == 'y' or flag_thickness == 'Y':
			thickness = thickness_mods(thickness)
			loop_thickness = False

		elif flag_thickness == 'n' or flag_thickness =='N':
			loop_thickness = False

		else:
			print('Please enter a valid answer')

	loop_camber = True

	while loop_camber:
		flag_camber = raw_input('Are any changes in camber properties desired?(y/n)')

		if flag_camber == 'y' or flag_camber == 'Y':
			camber = camber_mods(camber)
			loop_camber = False

		elif flag_camber == 'n' or flag_camber =='N':
			loop_camber = False

		else:
			print('Please enter a valid answer')

	return thickness, camber

def thickness_mods(thickness):
	ROWS     = list(set([int(thickness[i][0]) for i in range(1, len(thickness))]))
	SECTIONS = list(set([int(thickness[i][1]) for i in range(1, len(thickness))]))

	ROW_START = min(ROWS)
	ROW_END = max(ROWS)

	CURRENT_ROW = ROW_START

	while CURRENT_ROW <= ROW_END:
		print('Row ' + str(CURRENT_ROW))
		rowchange = raw_input('Any thickness changes to Row ' + str(CURRENT_ROW) + '? (y/n)\n')

		if rowchange == 'n' or rowchange == 'N':
			CURRENT_ROW += 1

		elif rowchange == 'y' or rowchange == 'Y':
			flag = raw_input('Apply same change to all ' + str(len(SECTIONS)) + ' Sections in Row ' + str(CURRENT_ROW) + '? (y/n)\n')
			counter = CURRENT_ROW - ROW_START

			if flag == 'y' or flag == 'Y':
				change_TKLE = raw_input('Change Leading Edge Thickness (TKLE)? (y/n)')

				if change_TKLE == 'y' or change_TKLE == 'Y':
					TKLE = raw_input('New Leading Edge Thickness (TKLE)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][2] = TKLE.strip()

				change_TKTE = raw_input('Change Trailing Edge Thickness (TKTE)? (y/n)')

				if change_TKTE == 'y' or change_TKTE == 'Y':
					TKTE = raw_input('New Trailing Edge Thickness (TKTE)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][3] = TKTE.strip()

				change_TKMAX = raw_input('Change Maximum Thickness as a Fraction of Axial Chord (TKMAX)? (y/n)')

				if change_TKMAX == 'y' or change_TKMAX == 'Y':
					TKMAX = raw_input('New Maximum Thickness as a Fraction of Axial Chord (TKMAX)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][4] = TKMAX.strip()

				change_XTMAX = raw_input('Change X-Location of Maximum Thickness as a Fraction of Axial Chord (XTMAX)? (y/n)')

				if change_XTMAX == 'y' or change_XTMAX == 'Y':
					XTMAX = raw_input('New X-Location of Maximum Thickness as a Fraction of Axial Chord (XTMAX)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][5] = XTMAX.strip()

				change_XMODLE = raw_input('Change Rounding Length at Leading Edge (XMODLE)? (y/n)')

				if change_XMODLE == 'y' or change_XMODLE == 'Y':
					XMODLE = raw_input('New Rounding Length at Leading Edge (XMODLE)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][6] = XMODLE.strip()

				change_XMODTE = raw_input('Change Rounding Length at Trailing Edge (XMODTE)? (y/n)')

				if change_XMODTE == 'y' or change_XMODTE == 'Y':
					XMODTE = raw_input('New Rounding Length at Trailing Edge (XMODTE)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][7] = XMODTE.strip()

				change_TKTYP = raw_input('Change Type (TKTYP)? (y/n)')

				if change_TKTYP == 'y' or change_TKTYP == 'Y':
					TKTYP = raw_input('New Type (TKTYP)')

					for sec in range(0, len(SECTIONS)):
						idx = counter * len(SECTIONS) + sec + 1
						thickness[idx][8] = TKTYP.strip()

				CURRENT_ROW += 1

			elif flag == 'n' or flag =='N':
				SECTION_START = min(SECTIONS)
				SECTION_END = max(SECTIONS)

				CURRENT_SECTION = SECTION_START

				while CURRENT_SECTION <= SECTION_END:
					print('Row ' + str(CURRENT_ROW) + ', Section ' + str(CURRENT_SECTION))
					sec = CURRENT_SECTION - SECTION_START

					change_TKLE = raw_input('Change Leading Edge Thickness (TKLE)? (y/n/d)')

					if change_TKLE == 'y' or change_TKLE == 'Y':
						TKLE = raw_input('New Leading Edge Thickness (TKLE)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][2] = TKLE.strip()

					elif change_TKLE == 'd' or change_TKLE == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_TKTE = raw_input('Change Trailing Edge Thickness (TKTE)? (y/n/d)')

					if change_TKTE == 'y' or change_TKTE == 'Y':
						TKTE = raw_input('New Trailing Edge Thickness (TKTE)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][3] = TKTE.strip()
					elif change_TKTE == 'd' or change_TKTE == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_TKMAX = raw_input('Change Maximum Thickness as a Fraction of Axial Chord (TKMAX)? (y/n/d)')

					if change_TKMAX == 'y' or change_TKMAX == 'Y':
						TKMAX = raw_input('New Maximum Thickness as a Fraction of Axial Chord (TKMAX)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][4] = TKMAX.strip()

					elif change_TKMAX == 'd' or change_TKMAX == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_XTMAX = raw_input('Change X-Location of Maximum Thickness as a Fraction of Axial Chord (XTMAX)? (y/n/d)')

					if change_XTMAX == 'y' or change_XTMAX == 'Y':
						XTMAX = raw_input('New X-Location of Maximum Thickness as a Fraction of Axial Chord (XTMAX)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][5] = XTMAX.strip()

					elif change_XTMAX == 'd' or change_XTMAX == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_XMODLE = raw_input('Change Rounding Length at Leading Edge (XMODLE)? (y/n/d)')

					if change_XMODLE == 'y' or change_XMODLE == 'Y':
						XMODLE = raw_input('New Rounding Length at Leading Edge (XMODLE)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][6] = XMODLE.strip()

					elif change_XMODLE == 'd' or change_XMODLE == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_XMODTE = raw_input('Change Rounding Length at Trailing Edge (XMODTE)? (y/n/d)')

					if change_XMODTE == 'y' or change_XMODTE == 'Y':
						XMODTE = raw_input('New Rounding Length at Trailing Edge (XMODTE)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][7] = XMODTE.strip()

					elif change_XMODTE == 'd' or change_XMODTE == 'D':
							CURRENT_SECTION = SECTION_END
							break

					change_TKTYP = raw_input('Change Type (TKTYP)? (y/n/d)')

					if change_TKTYP == 'y' or change_TKTYP == 'Y':
						TKTYP = raw_input('New Type (TKTYP)')
						idx = counter * len(SECTIONS) + CURRENT_SECTION + 1
						thickness[idx][8] = TKTYP.strip()

					elif change_TKTYP == 'd' or change_TKTYP == 'D':
							CURRENT_SECTION = SECTION_END
							break

					CURRENT_SECTION += 1

				CURRENT_ROW += 1

			else:
				print('Please enter a valid answer')

	return thickness

def camber_mods(camber):
	ROWS     = list(set([int(camber[i][0]) for i in range(1, len(camber))]))
	SECTIONS = list(set([int(camber[i][1]) for i in range(1, len(camber))]))

	ROW_START = min(ROWS)
	ROW_END = max(ROWS)

	CURRENT_ROW = ROW_START


	while CURRENT_ROW <= ROW_END:
		print('Row ' + str(CURRENT_ROW))


		rowchange = raw_input('Any camber changes to Row ' + str(CURRENT_ROW) + '? (y/n)\n')

		if rowchange == 'n' or rowchange == 'N':
			CURRENT_ROW += 1

		elif rowchange == 'y' or rowchange == 'Y':
			flag = raw_input('Apply same change to all ' + str(len(SECTIONS)) + ' Sections in Row ' + str(CURRENT_ROW) + '? (y/n)\n')
			counter = CURRENT_ROW - ROW_START

			if flag == 'y' or flag == 'Y':

				for point in range(0, CONTROL_POINTS):

					if point != 0 and point != CONTROL_POINTS - 1:
						changex = raw_input('Change X-Location of Control Point ' + str(point+1) + '?(y/n)')

						if changex == 'y' or changex == 'Y':
							valx = raw_input('New X-Location of Control Point:\n')

							for sec in range(0, len(SECTIONS)):
								idx =  counter*CONTROL_POINTS*len(SECTIONS) + sec*CONTROL_POINTS + point + 1
								camber[idx][2] = valx.strip()
				
					changec = raw_input('Change Camber Angle of Control Point ' + str(point + 1) + '?(y/n)')

					if changec == 'y' or changec == 'Y':
						valc = raw_input('Change Camber Angle by X Degrees:\n')

						for sec in range(0, len(SECTIONS)):
							idx = idx =  counter*CONTROL_POINTS*len(SECTIONS) + sec*CONTROL_POINTS + point + 1
							camber[idx][3] = str(float(camber[idx][3]) + float(valc)).strip()

				CURRENT_ROW += 1

			elif flag == 'n' or flag =='N':
				SECTION_START = min(SECTIONS)
				SECTION_END = max(SECTIONS)

				CURRENT_SECTION = SECTION_START

				while CURRENT_SECTION <= SECTION_END:
					print('Row ' + str(CURRENT_ROW) + ', Section ' + str(CURRENT_SECTION))
					sec = CURRENT_SECTION - SECTION_START
					for point in range(0, CONTROL_POINTS):

						if point != 0 and point != CONTROL_POINTS - 1:
							changex = raw_input('Change X-Location of Control Point ' + str(point+1) + '?(y/n/d)')

							if changex == 'y' or changex == 'Y':
								valx = raw_input('New X-Location of Control Point:\n')
								idx = idx =  counter*CONTROL_POINTS*len(SECTIONS) + sec*CONTROL_POINTS + point + 1
								camber[idx][2] = valx.strip()

							elif changex == 'd' or changex == 'D':
								CURRENT_SECTION = SECTION_END
								break

						changec = raw_input('Change Camber Angle of Control Point ' + str(point + 1) + '?(y/n/d)')

						if changec == 'y' or changec == 'Y':
							valc = raw_input('Change Camber Angle by X Degrees:\n')
							idx = idx =  counter*CONTROL_POINTS*len(SECTIONS) + sec*CONTROL_POINTS + point + 1
							camber[idx][3] = str(float(camber[idx][3]) + float(valc)).strip()

						elif changec == 'd' or changec == 'D':
								CURRENT_SECTION = SECTION_END
								break

					CURRENT_SECTION += 1

				CURRENT_ROW += 1

			else:
				print('Please enter a valid answer')

	return camber

def geo_output(geofile, thickness, camber):
	# Section Headers
	HEADER1 = ['ROW', 'SECTION', 'TKLE', 'TKTE' , 'TKMAX', 'XTMAX', 'XMODLE', 'XMODTE', 'TK_TYP']
	HEADER2 = ['ROW', 'SECTION', 'X'   , 'ANGLE']

	if thickness[0] != HEADER1 or camber[0] != HEADER2:
		print('Error, bad input file')
		exit()

	# Open File for Reading
	with open(geofile, 'w') as f:
		writer = csv.writer(f, delimiter = '\t')
		for row in thickness:
			writer.writerow(row)

		writer.writerow([''])

		for row in camber:
			writer.writerow(row)
		

# Generate New Stagen File
def new_stagen(fname, thickness, camber):
	# Open Old Stagen File for Reading
	f = open(fname, 'r')
	lines = f.readlines()
	f.close()

	# Command to Rename Old Stagen File
	command = ['mv '    + fname + ' stagen_original.dat']
	execute_commands(command)

	# Get Indices of Lines with Blade Row and Blade Section Information
	ROW_IDX     = [i for i, line in enumerate(lines) if 'ROW NUMBER'     in line and 'BLADE' not in line]
	SECTION_IDX = [i for i, line in enumerate(lines) if 'SECTION NUMBER' in line                        ]

	# Iterate Over Every Row and Section to Write to Update Lines to Write to New Stagen File
	for i in range(0, len(ROW_IDX)):
		# Strip Non-Numeric Characters 
		ROW_NUMBER = re.sub("[^0-9]", "", lines[ROW_IDX[i]])
		SECTION_NUMBER = re.sub("[^0-9]", "", lines[SECTION_IDX[i]])
		
		# Line Offset Value
		k = 5

		# Update Camber Values
		for j in range(0, len(camber)):
			if camber[j][0] == ROW_NUMBER and camber[j][1] == SECTION_NUMBER:
				lines[ROW_IDX[i]+k] = '      ' + camber[j][2] + '    ' + camber[j][3] + '    ' + 'BLADE CENTRE LINE ANGLES \n'
				k = k + 1				
		
		# Update Thickness Values
		for j in range(0, len(thickness)):
			if thickness[j][0] == ROW_NUMBER and thickness[j][1] == SECTION_NUMBER:
				lines[ROW_IDX[i]+11] = '    ' + thickness[j][2] + '    ' + thickness[j][3] + '    ' + thickness[j][4] + '    ' + thickness[j][5] + '    ' + thickness[j][6] + '    ' + thickness[j][7] + '    ' + thickness[j][8] + '     ' + 'BLADE PROFILE SPECFICATION\n'
	
	# Write Geometry to New Stagen File
	f = open(fname, 'w')
	f.writelines(lines)
	f.close()

def run_stagen(fname):
	command = ['./' + STAGEN + ' < ' + fname]
	execute_commands(command)

def blade_profiles(dir_new):
	command = ['matlab -nodesktop -nosplash -r "addpath ' + MATLAB + '; DE_airfoil ' + dir_new + '/' + GRID2D + '; DE_stagen_blade ' + dir_new + '/' + BLADE + '; exit;"']
	execute_commands(command)
	
	move_files('*.png', figures)

def modify_stage_new(fname, reynolds, ftin, fpin, p_back):
	ft_in = open(ftin, 'r')
	TIN_VEC = ft_in.readlines()
	ft_in.close()

	fp_in = open(fpin, 'r')
	PIN_VEC = fp_in.readlines()
	fp_in.close()

	f = open(fname, 'r')
	lines = f.readlines()
	f.close()

	REYNOLDS_HEADER = '   REYNO,     RF_VIS,   FTRANS, TURBVIS_LIM, PRANDTL, YPLUSWALL\n'
	REYNOLDS_IDX = [i for i, line in enumerate(lines) if 'REYNO' in line]

	if len(REYNOLDS_IDX) == 1:
		REYNOLDS_IDX = REYNOLDS_IDX[0]

		if lines[REYNOLDS_IDX] == REYNOLDS_HEADER:
			lines[REYNOLDS_IDX + 1] = '  ' + str(reynolds) + '     0.500     0.000  3000.000       1.0     0.000\n'

		else:
			print('Error with input file')
			exit()
	else:
		print('Error with input file')
		exit()

	PIN_HEADER = '   INLET STAGNATION PRESSURES \n'
	PIN_IDX = [i for i, line in enumerate(lines) if 'INLET STAGNATION PRESSURES' in line]

	if len(PIN_IDX) == 1:
		PIN_IDX = PIN_IDX[0]

		if lines[PIN_IDX] == PIN_HEADER:
			i = 1
			for line in PIN_VEC:
				lines[PIN_IDX + i] = line
				i = i + 1
		else:
			print('Error with input file')
			exit()
	else:
		print('Error with input file')
		exit()

	TIN_HEADER = '   INLET STAGNATION TEMPERATURES \n'
	TIN_IDX = [i for i, line in enumerate(lines) if 'INLET STAGNATION TEMPERATURES' in line]

	if len(TIN_IDX) == 1:
		TIN_IDX = TIN_IDX[0]

		if lines[TIN_IDX] == TIN_HEADER:
			i = 1
			for line in TIN_VEC:
				lines[TIN_IDX + i] = line
				i = i + 1
		else:
			print('Error with input file')
			exit()
	else:
		print('Error with input file')
		exit()

	PBACK_HEADER = '   PDOWN_HUB   PDOWN_TIP \n'
	PBACK_IDX = [i for i, line in enumerate(lines) if 'PDOWN_HUB' in line or 'PDOWN_TIP' in line]

	if len(PBACK_IDX) == 1:
		PBACK_IDX = PBACK_IDX[0]

		if lines[PBACK_IDX] == PBACK_HEADER:
			lines[PBACK_IDX + 1] = '  ' + str(p_back) + '  ' + str(p_back) + '\n'

		else:
			print('Error with input file')
			exit()
	else:
		print('Error with input file')
		exit()

	f = open(fname, 'w')
	f.writelines(lines)
	f.close()

def run_multall():
	commands = ['touch ' + INTYPE                 ,
                    'echo N > ' + INTYPE              ,
                    './' + MULTALL + ' < ' + STAGE_NEW ]

	execute_commands(commands)

def generate_matlab():
	command = ['./' + CONVERT_TO_MATLAB]
	execute_commands(command)

def generate_tecplot():
	command = ['./' + CONVERT_TO_TECPLOT]
	execute_commands(command)

def results_matlab(dir_new, mdatafile):
	mdatafile = dir_new + '/' + mdatafile

	pside = dir_new + '/' + Mach_PS
	sside = dir_new + '/' + Mach_SS

	DE_compare_PW = mdatafile + " " + dppop + " " + angles + " " + dfactor + " " + pwstag + " " + pstagold + " " + tstagold + " " + xrotor + " " + xstator
	DE_plot_Mach = pside + " " + sside + " " + xrotor + " " + xstator + " " + PW_Mach

	command = ['matlab -nodesktop -nosplash -r "addpath ' + MATLAB + '; DE_pitchwise_avg_1d ' + mdatafile + '; DE_compare_PW ' + DE_compare_PW + '; DE_compare_Mach ' + mdatafile + '; DE_plot_Mach ' + DE_plot_Mach + '; exit;"']

	execute_commands(command)

	move_files('*.png', figures)

def results_tecplot(dir_new, tecplotfile, meridionalfile):
	tecplotfile = dir_new + '/' + tecplotfile
	meridionalfile = dir_new + '/' + meridionalfile

	commands = ['tec360 -datafile ' + tecplotfile + ' -p ' + FLOW_FIELD + ' -b -nobatchlog',
		    'tec360 -datafile ' + meridionalfile + ' -p ' + MERIDIONAL + ' -b -nobatchlog',
                    'tec360 -datafile ' + tecplotfile + ' -p ' + BLADES_3D + ' -b -nobatchlog']

	execute_commands(commands)

	move_files(home_dir + '*.png', figures)

# Compare Modified Geometry Results to Current Geometry Results
def results_compare(dir_current, dir_modified):
	f_current = dir_current + '/matlab.dat'
	f_modified = dir_modified + '/matlab.dat'

	command = ['matlab -nodesktop -nosplash -r "addpath ' + MATLAB + '; DE_compare_two_op ' + f_current + ' ' + f_modified + '; Design_Study ' + dir_modified + '; exit;"',
		   'mkdir ' + figures + '/Comparison']

	execute_commands(command)

	move_files('*.png', figures + '/Comparison')
	
# Change Current Working Directory to New Working Directory
def change_wd(folder):
	print('CHANGING WORKING DIRECTORY FROM' + os.getcwd() + ' TO ' + folder + '\n')

	os.chdir(folder)
	cwd = os.getcwd()

	print('CURRENT WORKING DIRECTORY: ' + cwd + '\n')

# Execute Command in the Terminal
def execute_commands(commands):
	for command in commands:
		print('\nUser Command:\t' + command)

		try:
			os.system(command)
		except:
			print('An error occurred.')


def move_files(files, folder):
	command = ['mv ' + files + ' ' + folder]
	execute_commands(command)

main()
